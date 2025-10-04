import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
import cv2
import os
import base64
import json
from collections import Counter
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from datetime import datetime

# -------------------------
# All Available Models
# -------------------------
MODEL_NAMES = ["resnet50", "vgg16", "inceptionv3", "xception"]
MODEL_PATHS = {
    "resnet50": "./model/resnet50_model.h5",
    "vgg16": "./model/vgg16_model.h5",
    "inceptionv3": "./model/inceptionv3_model.h5",
    "xception": "./model/xception_model.h5"
}


# -------------------------
# Load all saved models
# -------------------------
models = {}
for model_name in MODEL_NAMES:
    try:
        models[model_name] = load_model(MODEL_PATHS[model_name])
        print(f"Loaded {model_name} model successfully")
    except Exception as e:
        print(f"Failed to load {model_name} model: {e}")

# Check if any models were loaded
if not models:
    raise ValueError("No models were loaded successfully. Please check model paths.")

# -------------------------
# Model configuration
# -------------------------
MODEL_CONFIGS = {
    "resnet50": {
        "input_size": (224, 224),
        "preprocess_func": tf.keras.applications.resnet50.preprocess_input
    },
    "vgg16": {
        "input_size": (224, 224),
        "preprocess_func": tf.keras.applications.vgg16.preprocess_input
    },
    "inceptionv3": {
        "input_size": (299, 299),
        "preprocess_func": tf.keras.applications.inception_v3.preprocess_input
    },
    "xception": {
        "input_size": (299, 299),
        "preprocess_func": tf.keras.applications.xception.preprocess_input
    }
}

# Warm-up calls for all models
for model_name, model in models.items():
    input_size = MODEL_CONFIGS[model_name]["input_size"]
    _dummy = np.zeros((1, input_size[0], input_size[1], 3), dtype=np.float32)
    _ = model.predict(_dummy)
    print(f"Warmed up {model_name} model")

# -------------------------
# Class labels
# -------------------------
class_labels = ['Bacterial Leaf Blight', 'Brown Spot', 'Healthy Rice Leaf',
                'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot',
                'Neck_Blast', 'Rice Hispa', 'Sheath Blight']

# -------------------------
# Preprocessing function
# -------------------------
def preprocess_image(img_path, model_name):
    input_size = MODEL_CONFIGS[model_name]["input_size"]

    original_img = cv2.imread(img_path)
    original_img = cv2.cvtColor(original_img, cv2.COLOR_BGR2RGB)

    img = image.load_img(img_path, target_size=input_size)
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)

    img_tensor = tf.convert_to_tensor(img_array, dtype=tf.float32)
    preprocess_func = MODEL_CONFIGS[model_name]["preprocess_func"]
    img_preprocessed = preprocess_func(img_tensor)

    return original_img, img_tensor, img_preprocessed

# -------------------------
# Utilities
# -------------------------
def create_output_directory():
    """Create output directory inside 'output/' with timestamp"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_dir = "output"
    output_dir = os.path.join(base_dir, f"multi_model_explainable_ai_{timestamp}")
    os.makedirs(output_dir, exist_ok=True)
    return output_dir

# -------------------------
# Explanation Generation Functions
# -------------------------
def generate_gradient_explanation(img_tensor, model, class_index=None):
    """Generate gradient-based explanation that always works"""
    with tf.GradientTape() as tape:
        tape.watch(img_tensor)
        predictions = model(img_tensor)
        if class_index is None:
            class_index = tf.argmax(predictions[0])
        class_output = predictions[:, class_index]

    # Get gradients
    gradients = tape.gradient(class_output, img_tensor)

    # Process gradients for visualization
    gradients = tf.abs(gradients)  # Take absolute value
    gradients = tf.reduce_mean(gradients, axis=-1)  # Average across channels
    gradients = gradients[0]  # Remove batch dimension

    # Normalize to 0-1
    gradients = (gradients - tf.reduce_min(gradients)) / (tf.reduce_max(gradients) - tf.reduce_min(gradients))

    return gradients.numpy()

def generate_smoothgrad_explanation(img_tensor, model, class_index=None, noise_level=0.1, n_samples=50):
    """Generate SmoothGrad explanation - reduces noise in gradients"""
    gradients_sum = tf.zeros_like(img_tensor)

    for _ in range(n_samples):
        # Add random noise
        noise = tf.random.normal(tf.shape(img_tensor)) * noise_level
        noisy_img = img_tensor + noise

        with tf.GradientTape() as tape:
            tape.watch(noisy_img)
            predictions = model(noisy_img)
            if class_index is None:
                class_index = tf.argmax(predictions[0])
            class_output = predictions[:, class_index]

        gradients = tape.gradient(class_output, noisy_img)
        gradients_sum += gradients

    # Average the gradients
    smooth_gradients = gradients_sum / n_samples

    # Process for visualization
    smooth_gradients = tf.abs(smooth_gradients)
    smooth_gradients = tf.reduce_mean(smooth_gradients, axis=-1)
    smooth_gradients = smooth_gradients[0]

    # Normalize
    smooth_gradients = (smooth_gradients - tf.reduce_min(smooth_gradients)) / \
                      (tf.reduce_max(smooth_gradients) - tf.reduce_min(smooth_gradients))

    return smooth_gradients.numpy()

# -------------------------
# Visualization Functions
# -------------------------
def create_heatmap_overlay(original_img, heatmap, colormap=cv2.COLORMAP_JET, alpha=0.4):
    """Create heatmap overlay on original image"""
    # Resize heatmap to match original image
    heatmap_resized = cv2.resize(heatmap, (original_img.shape[1], original_img.shape[0]))

    # Convert to 0-255 range
    heatmap_uint8 = np.uint8(255 * heatmap_resized)

    # Apply colormap
    heatmap_colored = cv2.applyColorMap(heatmap_uint8, colormap)
    heatmap_colored = cv2.cvtColor(heatmap_colored, cv2.COLOR_BGR2RGB)

    # Create overlay
    overlay = cv2.addWeighted(original_img, 1-alpha, heatmap_colored, alpha, 0)
    return overlay, heatmap_colored

def save_model_explanation(original_img, explanation, model_name, pred_class, confidence, filename, output_dir):
    """Save explanation for a single model"""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Original image
    axes[0].imshow(original_img)
    axes[0].set_title("Original Image")
    axes[0].axis('off')

    # Explanation heatmap
    axes[1].imshow(explanation, cmap='hot')
    axes[1].set_title(f"{model_name} Heatmap")
    axes[1].axis('off')

    # Overlay
    overlay, _ = create_heatmap_overlay(original_img, explanation, cv2.COLORMAP_JET)
    axes[2].imshow(overlay)
    axes[2].set_title(f"{model_name} Overlay")
    axes[2].axis('off')

    plt.suptitle(f"{model_name}: {class_labels[pred_class]} ({confidence:.1f}%)", fontsize=16)
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, filename), dpi=300, bbox_inches='tight')
    plt.close()

# -------------------------
# Paddy Leaf Detection Logic
# -------------------------
def is_paddy_leaf(predictions_dict, class_labels):
    """
    Determine if the image is a paddy leaf based on model agreement.
    Returns: (is_paddy_leaf, final_prediction, confidence)
    """
    # Count how many models predicted each class
    class_counts = Counter()
    model_predictions = {}

    for model_name, data in predictions_dict.items():
        pred_class = data["pred_class"]
        class_counts[pred_class] += 1
        model_predictions[model_name] = {
            "class": class_labels[pred_class],
            "confidence": data["confidence"]
        }

    # Find the most common prediction
    most_common = class_counts.most_common(1)
    if most_common:
        most_common_class, count = most_common[0]

        # Check if at least 3 models agree
        if count >= 3:
            # Find the model with highest confidence for this class
            best_model = None
            best_confidence = 0

            for model_name, data in predictions_dict.items():
                if data["pred_class"] == most_common_class and data["confidence"] > best_confidence:
                    best_confidence = data["confidence"]
                    best_model = model_name

            return True, class_labels[most_common_class], best_confidence, best_model
        else:
            # Not enough agreement - not a paddy leaf
            return False, "Not a paddy leaf", 0, None
    else:
        return False, "Not a paddy leaf", 0, None

# -------------------------
# Custom JSON Encoder for NumPy types
# -------------------------
class NumpyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        if isinstance(obj, np.floating):
            return float(obj)
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        if isinstance(obj, np.bool_):
            return bool(obj)
        return super(NumpyEncoder, self).default(obj)

# -------------------------
# Main Multi-Model Explainable AI Function
# -------------------------
def generate_multi_model_explanations(img_path, models, class_labels, output_dir=None):
    """
    Generate explainable AI visualizations for all models and save as images
    """
    if output_dir is None:
        output_dir = create_output_directory()

    print(f"Generating explainable AI visualizations for all models...")
    print(f"Output directory: {output_dir}")

    try:
        # Create a summary figure comparing all models
        n_models = len(models)
        fig, axes = plt.subplots(n_models, 4, figsize=(20, 5 * n_models))

        if n_models == 1:
            axes = axes.reshape(1, -1)  # Ensure 2D array even for single model

        analysis_data = {}

        # Print header for predictions
        print("\n" + "="*80)
        print("MODEL PREDICTIONS:")
        print("="*80)

        for i, (model_name, model) in enumerate(models.items()):
            print(f"Processing {model_name}...")

            # Preprocess image for this specific model
            original_img, img_tensor, img_preprocessed = preprocess_image(img_path, model_name)

            # Get predictions
            predictions = model.predict(img_preprocessed)
            pred_class = np.argmax(predictions[0])
            confidence = predictions[0][pred_class] * 100

            # Print prediction to terminal
            print(f"{model_name.upper():<15}: {class_labels[pred_class]:<30} ({confidence:.2f}%)")

            # Store analysis data
            analysis_data[model_name] = {
                "pred_class": pred_class,
                "confidence": confidence,
                "predictions": predictions[0]
            }

            # Generate explanation
            explanation = generate_smoothgrad_explanation(img_preprocessed, model, pred_class, n_samples=30)

            # Save individual model explanation
            save_model_explanation(
                original_img, explanation, model_name, pred_class, confidence,
                f"{model_name}_explanation.png", output_dir
            )

            # Add to summary figure
            # Original image (only once)
            if i == 0:
                axes[i, 0].imshow(original_img)
                axes[i, 0].set_title("Original Image")
            else:
                axes[i, 0].axis('off')

            # Heatmap
            axes[i, 1].imshow(explanation, cmap='hot')
            axes[i, 1].set_title(f"{model_name} Heatmap")
            axes[i, 1].axis('off')

            # Overlay
            overlay, _ = create_heatmap_overlay(original_img, explanation, cv2.COLORMAP_JET)
            axes[i, 2].imshow(overlay)
            axes[i, 2].set_title(f"{model_name} Overlay")
            axes[i, 2].axis('off')

            # Prediction text
            axes[i, 3].text(0.1, 0.5,
                           f"Model: {model_name}\n"
                           f"Prediction: {class_labels[pred_class]}\n"
                           f"Confidence: {confidence:.1f}%",
                           fontsize=12, va='center')
            axes[i, 3].axis('off')

        print("="*80)

        plt.suptitle(f"Multi-Model Explainable AI Analysis", fontsize=20)
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, 'multi_model_comparison.png'), dpi=300, bbox_inches='tight')
        plt.close()

        # Create prediction confidence comparison
        plt.figure(figsize=(12, 8))
        x_pos = np.arange(len(class_labels))
        colors = plt.cm.Set3(np.linspace(0, 1, len(models)))

        for j, (model_name, data) in enumerate(analysis_data.items()):
            plt.plot(x_pos, data["predictions"] * 100, 'o-', color=colors[j],
                    label=model_name, linewidth=2, markersize=8)

        plt.xlabel('Class Labels')
        plt.ylabel('Confidence (%)')
        plt.title('Model Confidence Comparison Across Classes')
        plt.xticks(x_pos, class_labels, rotation=45, ha='right')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, 'confidence_comparison.png'), dpi=300, bbox_inches='tight')
        plt.close()

        # Create agreement matrix
        agreement_matrix = np.zeros((len(models), len(models)))
        model_names_list = list(models.keys())

        for i, model1 in enumerate(model_names_list):
            for j, model2 in enumerate(model_names_list):
                if i == j:
                    agreement_matrix[i, j] = 1.0  # Same model always agrees
                else:
                    # Calculate agreement based on prediction similarity
                    pred1 = analysis_data[model1]["pred_class"]
                    pred2 = analysis_data[model2]["pred_class"]
                    conf1 = analysis_data[model1]["confidence"]
                    conf2 = analysis_data[model2]["confidence"]

                    if pred1 == pred2:
                        # Models agree on class, weight by average confidence
                        agreement_matrix[i, j] = (conf1 + conf2) / 200
                    else:
                        # Models disagree
                        agreement_matrix[i, j] = 0

        # Print agreement summary to terminal
        print("\nMODEL AGREEMENT SUMMARY:")
        print("="*80)
        for i, model1 in enumerate(model_names_list):
            for j, model2 in enumerate(model_names_list):
                if i < j:  # Only show each pair once
                    pred1 = analysis_data[model1]["pred_class"]
                    pred2 = analysis_data[model2]["pred_class"]

                    if pred1 == pred2:
                        print(f"{model1.upper()} and {model2.upper():<10}: AGREE on {class_labels[pred1]}")
                    else:
                        print(f"{model1.upper()} and {model2.upper():<10}: DISAGREE ({class_labels[pred1]} vs {class_labels[pred2]})")
        print("="*80)

        # Determine if it's a paddy leaf
        is_paddy, final_prediction, final_confidence, best_model = is_paddy_leaf(analysis_data, class_labels)

        # Print final determination
        print("\nFINAL DETERMINATION:")
        print("="*80)
        if is_paddy:
            print(f"✓ This is a paddy leaf with {final_prediction}")
            print(f"  Highest confidence: {final_confidence:.2f}% from {best_model}")
        else:
            print(f"✗ This is NOT a paddy leaf")
            print(f"  Not enough model agreement to identify a paddy leaf disease")
        print("="*80)

        # Plot agreement matrix
        plt.figure(figsize=(10, 8))
        plt.imshow(agreement_matrix, cmap='RdYlGn', vmin=0, vmax=1)
        plt.colorbar(label='Agreement Score')
        plt.xticks(np.arange(len(model_names_list)), model_names_list, rotation=45)
        plt.yticks(np.arange(len(model_names_list)), model_names_list)
        plt.title('Model Agreement Matrix')

        # Add text annotations
        for i in range(len(model_names_list)):
            for j in range(len(model_names_list)):
                plt.text(j, i, f'{agreement_matrix[i, j]:.2f}',
                        ha='center', va='center', color='black' if agreement_matrix[i, j] > 0.5 else 'black')

        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, 'agreement_matrix.png'), dpi=300, bbox_inches='tight')
        plt.close()

        # Create JSON summary
        json_summary = {
            "image_path": img_path,
            "analysis_date": datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            "is_paddy_leaf": bool(is_paddy),  # Convert numpy bool to Python bool
            "final_prediction": str(final_prediction),
            "final_confidence": float(final_confidence),
            "best_model": str(best_model) if best_model else None,
            "model_predictions": {},
            "model_agreement": {}
        }

        # Add model predictions
        for model_name, data in analysis_data.items():
            json_summary["model_predictions"][model_name] = {
                "predicted_class": str(class_labels[data["pred_class"]]),
                "confidence": float(data["confidence"]),
                "all_predictions": {str(class_labels[i]): float(prob * 100) for i, prob in enumerate(data["predictions"])}
            }

        # Add model agreement
        for i, model1 in enumerate(model_names_list):
            for j, model2 in enumerate(model_names_list):
                if i != j:
                    key = f"{model1}_{model2}"
                    pred1 = analysis_data[model1]["pred_class"]
                    pred2 = analysis_data[model2]["pred_class"]
                    json_summary["model_agreement"][key] = {
                        "agree": bool(pred1 == pred2),  # Convert numpy bool to Python bool
                        "class1": str(class_labels[pred1]),
                        "class2": str(class_labels[pred2]),
                        "agreement_score": float(agreement_matrix[i, j])
                    }

        # Save JSON summary with custom encoder
        with open(os.path.join(output_dir, 'multi_model_summary.json'), 'w') as f:
            json.dump(json_summary, f, indent=4, cls=NumpyEncoder)

        # Create analysis report
        with open(os.path.join(output_dir, 'multi_model_analysis_report.txt'), 'w') as f:
            f.write("MULTI-MODEL EXPLAINABLE AI ANALYSIS REPORT\n")
            f.write("=" * 60 + "\n\n")
            f.write(f"Image: {img_path}\n")
            f.write(f"Analysis Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

            f.write("FINAL DETERMINATION:\n")
            f.write("-" * 30 + "\n")
            if is_paddy:
                f.write(f"This is a paddy leaf with {final_prediction}\n")
                f.write(f"Highest confidence: {final_confidence:.2f}% from {best_model}\n")
            else:
                f.write("This is NOT a paddy leaf\n")
                f.write("Not enough model agreement to identify a paddy leaf disease\n")

            f.write("\nMODEL PREDICTIONS:\n")
            f.write("-" * 30 + "\n")
            for model_name, data in analysis_data.items():
                f.write(f"{model_name}: {class_labels[data['pred_class']]} ({data['confidence']:.2f}%)\n")

            f.write("\nDETAILED PREDICTIONS:\n")
            f.write("-" * 30 + "\n")
            for model_name, data in analysis_data.items():
                f.write(f"\n{model_name}:\n")
                top_5_indices = np.argsort(data["predictions"])[-5:][::-1]
                for idx in top_5_indices:
                    f.write(f"  {class_labels[idx]}: {data['predictions'][idx]*100:.2f}%\n")

            f.write(f"\nGenerated Files:\n")
            f.write("- multi_model_comparison.png - Side-by-side model comparisons\n")
            f.write("- confidence_comparison.png - Confidence scores across classes\n")
            f.write("- agreement_matrix.png - Model agreement visualization\n")
            f.write("- multi_model_summary.json - JSON summary of all results\n")
            for model_name in models.keys():
                f.write(f"- {model_name}_explanation.png - Individual model explanation\n")

        print(f"\nMulti-model explainable AI analysis complete!")
        print(f"All visualizations saved in: {output_dir}")

        return output_dir

    except Exception as e:
        print(f"Error during multi-model analysis: {e}")
        import traceback
        traceback.print_exc()

        return output_dir


# -------------------------
# FastAPI Backend
# -------------------------
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import shutil

app = FastAPI()
app = FastAPI()

# Define disease classes
DISEASE_CLASSES = [
    'Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 
    'Leaf scald', 'Narrow Brown Leaf Spot', 'Neck_Blast', 
    'Rice Hispa', 'Sheath Blight'
]
HEALTHY_CLASS = "Healthy Rice Leaf"

@app.post("/analyze")
async def analyze_image(file: UploadFile = File(...)):
    temp_dir = "temp_uploads"
    os.makedirs(temp_dir, exist_ok=True)

    temp_path = os.path.join(temp_dir, file.filename)
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Run your model
    output_dir = generate_multi_model_explanations(temp_path, models, class_labels)

    # Read report file
    report_file = os.path.join(output_dir, "multi_model_analysis_report.txt")
    report_content = None
    if os.path.exists(report_file):
        with open(report_file, "r") as f:
            report_content = f.read()

    # Read summary file
    summary_file = os.path.join(output_dir, "multi_model_summary.json")
    summary_content = None
    disease_name = "Unknown"
    status_code = 2  # default "Not Paddy"

    if os.path.exists(summary_file):
        with open(summary_file, "r") as f:
            summary_content = f.read()

        try:
            summary_json = json.loads(summary_content)
            disease_name = summary_json.get("final_prediction", "Unknown")

            # Assign status code
            if disease_name == HEALTHY_CLASS:
                status_code = 0
            elif disease_name in DISEASE_CLASSES:
                status_code = 1
            else:
                status_code = 2
        except Exception:
            pass

    # Encode images to base64
    image_data = {}
    for fname in os.listdir(output_dir):
        if fname.endswith(".png"):
            with open(os.path.join(output_dir, fname), "rb") as img_f:
                b64_img = base64.b64encode(img_f.read()).decode("utf-8")
                image_data[fname] = b64_img

    # Clean temp
    os.remove(temp_path)

    response = {
        "disease": disease_name,
        "status_code": status_code,   # New mapped key
        "report": report_content,
        "summary": summary_content,
        "images": image_data
    }

    return JSONResponse(content=response)    