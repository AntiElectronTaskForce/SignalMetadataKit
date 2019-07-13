//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import Foundation

// See:
// https://github.com/signalapp/libsignal-metadata-java/blob/cac0dde9de416a192e64a8940503982820870090/java/src/main/java/org/signal/libsignal/metadata/certificate/SenderCertificate.java
@objc public class SMKSenderCertificate: NSObject {

    @objc public let signer: SMKServerCertificate
    @objc public let key: ECPublicKey
    @objc public let senderDeviceId: UInt32
    @objc public let senderRecipientId: String
    @objc public let expirationTimestamp: UInt64
    @objc public let serializedData: Data
    @objc public let certificateData: Data
    @objc public let signatureData: Data

    public init(serializedData: Data) throws {
        // SignalProtos.SenderCertificate wrapper = SignalProtos.SenderCertificate.parseFrom(serialized);
        //
        // if (!wrapper.hasSignature() || !wrapper.hasCertificate()) {
        //     throw new InvalidCertificateException("Missing fields");
        // }
        let wrapperProto = try SMKProtoSenderCertificate.parseData(serializedData)

        // SignalProtos.SenderCertificate.Certificate certificate = SignalProtos.SenderCertificate.Certificate.parseFrom(wrapper.getCertificate());
        //
        // if (!certificate.hasSigner() || !certificate.hasIdentityKey() || !certificate.hasSenderDevice() || !certificate.hasExpires() || !certificate.hasSender()) {
        //     throw new InvalidCertificateException("Missing fields");
        // }
        let certificateProto = try SMKProtoSenderCertificateCertificate.parseData(wrapperProto.certificate)

        // this.signer         = new ServerCertificate(certificate.getSigner().toByteArray());
        // this.key            = Curve.decodePoint(certificate.getIdentityKey().toByteArray(), 0);
        // this.sender         = certificate.getSender();
        // this.senderDeviceId = certificate.getSenderDevice();
        // this.expiration     = certificate.getExpires();
        self.signer = try SMKServerCertificate(serializedData: certificateProto.signer.serializedData())
        self.key = try ECPublicKey(serializedKeyData: certificateProto.identityKey)
        self.senderRecipientId = certificateProto.sender
        self.senderDeviceId = certificateProto.senderDevice
        self.expirationTimestamp = certificateProto.expires

        // this.serialized  = serialized;
        // this.certificate = wrapper.getCertificate().toByteArray();
        // this.signature   = wrapper.getSignature().toByteArray();
        self.serializedData = serializedData
        self.certificateData = wrapperProto.certificate
        self.signatureData = wrapperProto.signature
    }
}
