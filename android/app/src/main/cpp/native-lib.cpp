#include <jni.h>
#include <string>
#include "include/td/telegram/td_json_client.h"
#include "include/td/telegram/td_log.h"


extern "C"
JNIEXPORT jstring JNICALL
Java_in_betaturtle_flugram_MainActivity_nativeClientReceive(JNIEnv *env, jobject instance,
                                                      jlong client_id, jdouble wait_timeout) {

    void *client = reinterpret_cast<void *>(static_cast<std::uintptr_t>(client_id));
    const char *result = td_json_client_receive(client, wait_timeout);
    return env->NewStringUTF(result);
}


extern "C"
JNIEXPORT void JNICALL
Java_in_betaturtle_flugram_MainActivity_nativeClientSend(JNIEnv *env, jobject instance, jlong client_id,
                                                   jstring json_) {
    const char *json = env->GetStringUTFChars(json_, 0);
    void *client = reinterpret_cast<void *>(static_cast<std::uintptr_t>(client_id));
    td_json_client_send(client, json);
    env->ReleaseStringUTFChars(json_, json);
}


extern "C"
JNIEXPORT jstring JNICALL
Java_in_betaturtle_flugram_MainActivity_nativeClientExecute(JNIEnv *env, jobject instance,
                                                      jlong client_id, jstring json_) {
    const char *json = env->GetStringUTFChars(json_, 0);
    void *client = reinterpret_cast<void *>(static_cast<std::uintptr_t>(client_id));
    const char *result = td_json_client_execute(client, json);
    env->ReleaseStringUTFChars(json_, json);
    return env->NewStringUTF(result);
}


extern "C"
JNIEXPORT void JNICALL
Java_in_betaturtle_flugram_MainActivity_destroyNativeClient(JNIEnv *env, jobject instance,
                                                      jlong client_id) {
    void *client = reinterpret_cast<void *>(static_cast<std::uintptr_t>(client_id));
    td_json_client_destroy(client);

}

extern "C"
JNIEXPORT jlong JNICALL
Java_in_betaturtle_flugram_MainActivity_createNativeClient(JNIEnv *env, jobject instance) {

    void *client = td_json_client_create();
    return reinterpret_cast<jlong>(client);

}extern "C"
JNIEXPORT void JNICALL
Java_in_betaturtle_flugram_MainActivity_setLogVerbosity(JNIEnv *env, jobject instance,
                                                         jint level) {

    td_set_log_verbosity_level(level);
}