#include "BLEService.h"
#include "../../include/config.h"
#include <ArduinoJson.h>

class ServerCallbacks : public NimBLEServerCallbacks {
public:
    bool* connected;
    void onConnect(NimBLEServer* s) override {
        *connected = true;
        Serial.println("[BLE] Client connected");
    }
    void onDisconnect(NimBLEServer* s) override {
        *connected = false;
        Serial.println("[BLE] Client disconnected — restarting advertising");
        s->startAdvertising();
    }
};

void BLEServiceRADIAN::begin() {
    NimBLEDevice::init(BLE_DEVICE_NAME);
    NimBLEDevice::setPower(ESP_PWR_LVL_P9);

    _server = NimBLEDevice::createServer();

    auto* cb = new ServerCallbacks();
    cb->connected = &_connected;
    _server->setCallbacks(cb);

    NimBLEService* service = _server->createService(BLE_SERVICE_UUID);

    _characteristic = service->createCharacteristic(
        BLE_CHAR_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );

    service->start();

    NimBLEAdvertising* adv = NimBLEDevice::getAdvertising();
    adv->addServiceUUID(BLE_SERVICE_UUID);
    adv->start();

    Serial.println("[BLE] Advertising as RADIAN");
}

String BLEServiceRADIAN::buildJSON(ComputedPayload& p) {
    StaticJsonDocument<200> doc;
    doc["mode"] = p.mode;
    doc["a1"]   = serialized(String(p.a1,   1));
    doc["a2"]   = serialized(String(p.a2,   1));

    JsonObject val = doc.createNestedObject("val");
    val["rad"]  = serialized(String(p.rad,      3));
    val["rx"]   = serialized(String(p.rx,       3));
    val["ry"]   = serialized(String(p.ry,       3));
    val["rmag"] = serialized(String(p.rmag,     2));
    val["rang"] = serialized(String(p.rang,     2));
    val["snap"] = p.snap;
    val["int"]  = serialized(String(p.interior, 1));
    val["ext"]  = serialized(String(p.exterior, 1));

    doc["ts"] = p.ts;

    String output;
    serializeJson(doc, output);
    return output;
}

void BLEServiceRADIAN::notify(ComputedPayload& payload) {
    if (!_connected) return;
    String json = buildJSON(payload);
    _characteristic->setValue(json.c_str());
    _characteristic->notify();
}

bool BLEServiceRADIAN::isConnected() {
    return _connected;
}