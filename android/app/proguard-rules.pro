# Keep com.crazecoder.openfile / openfilex classes to prevent R8 from stripping them in release builds
-keep class com.crazecoder.openfile.** { *; }
-keep class com.crazecoder.openfilex.** { *; }
-keepattributes *Annotation*,Signature
