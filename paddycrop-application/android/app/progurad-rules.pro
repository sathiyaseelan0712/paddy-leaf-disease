-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.gpu.** { *; }
-ignorewarnings
-keep class * {
  public private *;
 }