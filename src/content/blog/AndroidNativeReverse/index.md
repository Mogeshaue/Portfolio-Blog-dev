---
title: "Cracking Native Libraries on Android"
summary: "Ever wondered how some Android apps seem to hide all their secrets in native code, far from the friendly land of java or Kotlin? Welcome to the mysterious world of .so files, JNI, and a bit of reverse engineering wizardry."
date: "Apr 29 2025"
draft: false
tags:
  - android
---



##  The Native Side of Android

Most Android apps are written in java/Kotlin. But when they want more **speed**, **security**, or just to be extra sneaky 👀, they use **native code** — written in **C or C++** and compiled into `.so` shared libraries.

These `.so` files:

- Are compiled for your phone’s CPU (ARM, x86, etc.)
    
- Run natively — not in the JVM
    
- Usually hide sensitive logic like license checks, encryption, or flag validation in C/C++
    

---

##  Meet JNI: java’s Plug to the Native Matrix

> java Native Interface (JNI) = a bridge between java/Kotlin and C/C++

It lets java code call native code and vice versa. Think of it as:

```
Android java/Kotlin ↔ C/C++ (.so file)
```

You write something like this in java:

```
public native int add(int a, int b); // We declare it, but code lives in C/C++

static {
    System.loadLibrary("native-lib"); // This loads native-lib.so
}
```

And the native part (in C++) looks like:

```
JNIEXPORT jint JNICALL
java_com_example_MyClass_add(JNIEnv* env, jobject obj, jint a, jint b) {
    return a + b; // Finally, C does some work!
}
```

Yes, that method name is ridiculously long. But it's how **JNI dynamically links** your java method to the correct C function.

---

##  So, What the Heck Is `JNIEnv*`?

Glad you asked.

`JNIEnv*` is like your **remote control** to java — from inside native code. It lets C/C++ do things like:

- Create java objects
    
- Call java methods
    
- Throw exceptions
    
- Manipulate strings, arrays, etc.
    

### The Call Flow

```
MainActivity.java
    ↓
Calls native method `add()`
    ↓
JNI jumps into .so file
    ↓
Runs C++ function `java_com_example_MyClass_add(...)`
    ↓
You can now "talk back" to java via JNIEnv*
```

In short: you're in C, but still whispering sweet java nothings. 💬

---

##  Two Ways to Link java <--> C/C++

There are two flavors of JNI linking:

### 1. **Dynamic Linking**

You follow the naming pattern:

```
java_<package>_<Class>_<method>
```

java:

```
public native void sayHello();
```

C/C++:

```
JNIEXPORT void JNICALL
java_com_example_myapp_MyClass_sayHello(JNIEnv* env, jobject obj) {
    printf("Hi!\n");
}
```

### 2. **Static Linking** (a.k.a. I’m too cool for long names)

Here, you **register** native functions manually using `RegisterNatives`.

java:

```
public native String doWork(int num);
```

C++:

```
jstring myFunction(JNIEnv* env, jobject obj, jint num) {
    return env->NewStringUTF("Work done!");
}
```

Then, you tell java:  
“Hey! When you call `doWork()`, run `myFunction()` instead.”

```
static JNINativeMethod methods[] = {
    {"doWork", "(I)Ljava/lang/String;", (void*)myFunction}
};
```
Let’s break down that strange-looking method signature:

|Part|Meaning|
|---|---|
|`I`|Parameter is an `int`|
|`Ljava/lang/String;`|Return type is `String`|
|`()`|Wraps the arguments|

Finally, we register it when the library is loaded:

```
JNIEXPORT jint JNICALL JNI_OnLoad(javaVM* vm, void* reserved) {
    JNIEnv* env;
    vm->GetEnv((void**)&env, JNI_VERSION_1_6);

    jclass clazz = env->FindClass("com/example/MyClass");
    env->RegisterNatives(clazz, methods, 1);

    return JNI_VERSION_1_6;
}
```

Boom. Static linkage.

> Bonus: This can make reverse engineering harder because names don’t follow that java-style pattern. 😏

---

##  Reversing .so Files Like a Pro

When you're reversing an APK with `.so` files:

1. **Use JADX** to check out the java code
    
2. Find `native` method declarations
    
3. Open the `.so` in **Ghidra** (or IDA, or Hopper)
    
4. If it’s static linkage, look for `RegisterNatives`
    
5. If it’s dynamic, look for those long, ugly `java_com_example_X_Y` names
    
6. Match the signatures and figure out the logic
    

### Bonus: Ghidra + JNI

To make life easier, load JNI definitions:

1. Grab a `.gdt` file like `jni_all.gdt`
    
2. Import it in Ghidra
    
3. Go to your function
    
4. Right-click the first parameter (usually `undefined *param_1`)
    
5. Change it to `JNIEnv *`
    

Now your disassembly starts to make sense and looks a bit less like alien script.

---

##  TL;DR

- Native code (`.so` files) runs directly on the CPU, often hiding secrets.
    
- JNI is the bridge between java and native.
    
- Use `JNIEnv*` to manipulate java stuff from C.
    
- Linking can be **dynamic** (name-based) or **static** (`RegisterNatives`).
    
- Reverse engineering involves jadx + Ghidra (with JNI definitions).
    

---

 **Fun Fact**: If you ever find yourself naming a function like  
`java_com_super_secure_bankapp_MoneyManager_validateUser`,  
just know some reverse engineer is gonna find it in 5 seconds. Use `RegisterNatives` if you’re feeling spicy. 🌶️

---

Want help reversing a real `.so` file or decoding a flag? Hit me up! 😎

