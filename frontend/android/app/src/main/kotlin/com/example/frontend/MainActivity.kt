package com.example.frontend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.uhf.base.UHFManager
import com.uhf.base.UHFModuleType

class MainActivity : FlutterActivity() {
   private val CHANNEL = "uhf_scanner"
   private lateinit var uhfManager: UHFManager
   private var hasRFID = false
   private var isContinuousScanning = false
   private var continuousScanThread: Thread? = null
   
   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
       super.configureFlutterEngine(flutterEngine)
       
       try {
           // ลองสร้าง UHFManager
           uhfManager = UHFManager.getUHFImplSigleInstance(UHFModuleType.SLR_MODULE)
           hasRFID = true
           println("RFID hardware detected - setting up RFID functions")
           
           // ถ้าสำเร็จ = มี RFID → ตั้ง RFID functions
           setupRFIDChannel(flutterEngine)
           
       } catch (e: Exception) {
           // ถ้า error = ไม่มี RFID → ไม่ต้องทำอะไร
           hasRFID = false
           println("No RFID hardware detected: ${e.message}")
       }
   }
   
   private fun setupRFIDChannel(flutterEngine: FlutterEngine) {
       MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
           .setMethodCallHandler { call, result ->
               when (call.method) {
                   "powerOn" -> {
                       val success = uhfManager.powerOn()
                       result.success(success)
                   }
                   "powerOff" -> {
                       stopContinuousScan()
                       val success = uhfManager.powerOff()
                       result.success(success)
                   }
                   "scan" -> {
                       uhfManager.startInventoryTag()
                       Thread.sleep(1000)
                       val tagData = uhfManager.readTagFromBuffer()
                       uhfManager.stopInventory()
                       result.success(tagData?.get(1) ?: "ไม่พบแท็ก")
                   }
                   "setPower" -> {
                       val power = call.argument<Int>("power") ?: 20
                       val success = uhfManager.powerSet(power)
                       result.success(success)
                   }
                   "getPower" -> {
                       val power = uhfManager.powerGet()
                       result.success(power)
                   }
                   "setFrequency" -> {
                       val frequency = call.argument<Int>("frequency") ?: 3
                       val success = uhfManager.frequencyModeSet(frequency)
                       result.success(success)
                   }
                   "getFrequency" -> {
                       val frequency = uhfManager.frequencyModeGetNotFixedFreq()
                       result.success(frequency)
                   }
                   "startContinuousScan" -> {
                       startContinuousScan()
                       result.success(true)
                   }
                   "stopContinuousScan" -> {
                       stopContinuousScan()
                       result.success(true)
                   }
                   "hasRFID" -> {
                       result.success(hasRFID)
                   }
                   else -> result.notImplemented()
               }
           }
   }
   
   private fun startContinuousScan() {
       if (isContinuousScanning) return
       
       isContinuousScanning = true
       uhfManager.startInventoryTag()
       
       continuousScanThread = Thread {
           while (isContinuousScanning) {
               try {
                   val tagData = uhfManager.readTagFromBuffer()
                   if (tagData != null && tagData[1] != null) {
                       runOnUiThread {
                           MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                               .invokeMethod("onTagFound", tagData[1])
                       }
                   }
                   Thread.sleep(200) // 0.2 วินาที
               } catch (e: Exception) {
                   e.printStackTrace()
               }
           }
       }
       continuousScanThread?.start()
   }
   
   private fun stopContinuousScan() {
       isContinuousScanning = false
       uhfManager.stopInventory()
       continuousScanThread?.interrupt()
       continuousScanThread = null
   }
   
   override fun onDestroy() {
       if (hasRFID) {
           stopContinuousScan()
       }
       super.onDestroy()
   }
}