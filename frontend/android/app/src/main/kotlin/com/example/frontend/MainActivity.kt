package com.example.frontend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "uhf_scanner"
    private var uhfManager: Any? = null
    private var hasRFID = false
    private var isContinuousScanning = false
    private var continuousScanThread: Thread? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // ลอง check class ก่อนว่ามีไหม
        try {
            val uhfManagerClass = Class.forName("com.uhf.base.UHFManager")
            val moduleTypeClass = Class.forName("com.uhf.base.UHFModuleType")
            
            // ถ้ามี class = มี library
            val slrModule = moduleTypeClass.getField("SLR_MODULE").get(null)
            val method = uhfManagerClass.getMethod("getUHFImplSigleInstance", moduleTypeClass)
            uhfManager = method.invoke(null, slrModule)
            hasRFID = true
            println("✅ RFID Hardware available")
            
        } catch (e: ClassNotFoundException) {
            hasRFID = false
            println("❌ RFID Library not found")
        } catch (e: UnsatisfiedLinkError) {
            hasRFID = false
            println("❌ RFID Native library not found")
        } catch (e: Exception) {
            hasRFID = false
            println("❌ RFID Hardware error: ${e.message}")
        }
        
        setupMethodChannel(flutterEngine)
    }
    
    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasRFID" -> {
                        result.success(hasRFID)
                    }
                    "powerOn" -> {
                        if (hasRFID) {
                            try {
                                val method = uhfManager!!::class.java.getMethod("powerOn")
                                val success = method.invoke(uhfManager) as Boolean
                                result.success(success)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "powerOff" -> {
                        if (hasRFID) {
                            try {
                                stopContinuousScan()
                                val method = uhfManager!!::class.java.getMethod("powerOff")
                                val success = method.invoke(uhfManager) as Boolean
                                result.success(success)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "scan" -> {
                        if (hasRFID) {
                            try {
                                val startMethod = uhfManager!!::class.java.getMethod("startInventoryTag")
                                startMethod.invoke(uhfManager)
                                Thread.sleep(1000)
                                val readMethod = uhfManager!!::class.java.getMethod("readTagFromBuffer")
                                val tagData = readMethod.invoke(uhfManager) as? Array<String>
                                val stopMethod = uhfManager!!::class.java.getMethod("stopInventory")
                                stopMethod.invoke(uhfManager)
                                result.success(tagData?.get(1) ?: "ไม่พบแท็ก")
                            } catch (e: Exception) {
                                result.success("Error: ${e.message}")
                            }
                        } else {
                            result.success("ไม่มี RFID hardware")
                        }
                    }
                    "setPower" -> {
                        if (hasRFID) {
                            try {
                                val power = call.argument<Int>("power") ?: 20
                                val method = uhfManager!!::class.java.getMethod("powerSet", Int::class.java)
                                val success = method.invoke(uhfManager, power) as Boolean
                                result.success(success)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "getPower" -> {
                        if (hasRFID) {
                            try {
                                val method = uhfManager!!::class.java.getMethod("powerGet")
                                val power = method.invoke(uhfManager) as Int
                                result.success(power)
                            } catch (e: Exception) {
                                result.success(-1)
                            }
                        } else {
                            result.success(-1)
                        }
                    }
                    "setFrequency" -> {
                        if (hasRFID) {
                            try {
                                val frequency = call.argument<Int>("frequency") ?: 3
                                val method = uhfManager!!::class.java.getMethod("frequencyModeSet", Int::class.java)
                                val success = method.invoke(uhfManager, frequency) as Boolean
                                result.success(success)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "getFrequency" -> {
                        if (hasRFID) {
                            try {
                                val method = uhfManager!!::class.java.getMethod("frequencyModeGetNotFixedFreq")
                                val frequency = method.invoke(uhfManager) as Int
                                result.success(frequency)
                            } catch (e: Exception) {
                                result.success(-1)
                            }
                        } else {
                            result.success(-1)
                        }
                    }
                    "startContinuousScan" -> {
                        if (hasRFID) {
                            startContinuousScan()
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    "stopContinuousScan" -> {
                        if (hasRFID) {
                            stopContinuousScan()
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun startContinuousScan() {
        if (isContinuousScanning || !hasRFID) return
        
        isContinuousScanning = true
        try {
            val method = uhfManager!!::class.java.getMethod("startInventoryTag")
            method.invoke(uhfManager)
            
            continuousScanThread = Thread {
                while (isContinuousScanning) {
                    try {
                        val readMethod = uhfManager!!::class.java.getMethod("readTagFromBuffer")
                        val tagData = readMethod.invoke(uhfManager) as? Array<String>
                        if (tagData != null && tagData.size > 1 && tagData[1] != null) {
                            runOnUiThread {
                                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                                    .invokeMethod("onTagFound", tagData[1])
                            }
                        }
                        Thread.sleep(200)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            continuousScanThread?.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun stopContinuousScan() {
        isContinuousScanning = false
        if (hasRFID) {
            try {
                val method = uhfManager!!::class.java.getMethod("stopInventory")
                method.invoke(uhfManager)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
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