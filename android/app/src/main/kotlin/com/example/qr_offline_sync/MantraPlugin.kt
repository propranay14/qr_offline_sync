package com.example.qr_offline_sync

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import com.mantra.mfs100.FingerData
import com.mantra.mfs100.MFS100
import com.mantra.mfs100.MFS100Event
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MantraPlugin(
    private val context: Context
) : MethodChannel.MethodCallHandler, MFS100Event {

    private var mfs100: MFS100? = null

    private fun getScanner(): MFS100 {
        if (mfs100 == null) {
            mfs100 = MFS100(this)
            mfs100!!.SetApplicationContext(context)
        }
        return mfs100!!
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        when (call.method) {

            "initScanner" -> {

                val ret = getScanner().Init()

                if (ret == 0) {
                    result.success(true)
                } else {
                    result.error(
                        "INIT_FAILED",
                        getScanner().GetErrorMsg(ret),
                        null
                    )
                }
            }

            "captureFingerprint" -> {

                val fingerData = FingerData()

                val ret =
                    getScanner().AutoCapture(
                        fingerData,
                        10000,
                        false
                    )

                if (ret != 0) {

                    result.error(
                        "CAPTURE_FAILED",
                        getScanner().GetErrorMsg(ret),
                        null
                    )

                    return
                }

                val bitmap =
                    BitmapFactory.decodeByteArray(
                        fingerData.FingerImage(),
                        0,
                        fingerData.FingerImage().size
                    )

                val stream = ByteArrayOutputStream()

                bitmap.compress(
                    Bitmap.CompressFormat.PNG,
                    100,
                    stream
                )

                val imageBase64 =
                    Base64.encodeToString(
                        stream.toByteArray(),
                        Base64.NO_WRAP
                    )

                val isoBase64 =
                    Base64.encodeToString(
                        fingerData.ISOTemplate(),
                        Base64.NO_WRAP
                    )

                result.success(
                    mapOf(
                        "quality" to fingerData.Quality(),
                        "nfiq" to fingerData.Nfiq(),
                        "image" to imageBase64,
                        "template" to isoBase64
                    )
                )
            }

            "disposeScanner" -> {

                getScanner().UnInit()
                getScanner().Dispose()

                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    override fun OnDeviceAttached(
        vid: Int,
        pid: Int,
        hasPermission: Boolean
    ) {

        if (!hasPermission) return

        if (pid == 34323) {

            getScanner().LoadFirmware()

        } else if (pid == 4101) {

            getScanner().Init()

        }
    }

    override fun OnDeviceDetached() {

        getScanner().UnInit()

    }

    override fun OnHostCheckFailed(err: String?) {
    }
}