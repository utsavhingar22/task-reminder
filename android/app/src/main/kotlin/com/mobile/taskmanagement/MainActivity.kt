package com.mobile.taskmanagement

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mobile.taskmanagment/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDate" -> {
                    val initialYear = call.argument<Int>("initialYear") ?: Calendar.getInstance().get(Calendar.YEAR)
                    val initialMonth = call.argument<Int>("initialMonth") ?: Calendar.getInstance().get(Calendar.MONTH)
                    val initialDay = call.argument<Int>("initialDay") ?: Calendar.getInstance().get(Calendar.DAY_OF_MONTH)
                    
                    val datePickerDialog = DatePickerDialog(
                        this,
                        { _, year, month, dayOfMonth ->
                            val resultMap = mapOf(
                                "year" to year,
                                "month" to month,
                                "day" to dayOfMonth
                            )
                            result.success(resultMap)
                        },
                        initialYear,
                        initialMonth,
                        initialDay
                    )
                    datePickerDialog.show()
                }
                
                "pickTime" -> {
                    val initialHour = call.argument<Int>("initialHour") ?: Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
                    val initialMinute = call.argument<Int>("initialMinute") ?: Calendar.getInstance().get(Calendar.MINUTE)
                    
                    val timePickerDialog = TimePickerDialog(
                        this,
                        { _, hourOfDay, minute ->
                            val resultMap = mapOf(
                                "hour" to hourOfDay,
                                "minute" to minute
                            )
                            result.success(resultMap)
                        },
                        initialHour,
                        initialMinute,
                        true // 24-hour format
                    )
                    timePickerDialog.show()
                }
                
                "haptic" -> {
                    triggerHapticFeedback()
                    result.success(null)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun triggerHapticFeedback() {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(50)
        }
    }
}
