package com.capstone.travelbusan.domain.notification.service;

import com.capstone.travelbusan.domain.notification.entity.FcmToken;
import com.capstone.travelbusan.domain.notification.repository.FcmTokenRepository;
import com.capstone.travelbusan.domain.user.entity.User;
import com.capstone.travelbusan.domain.user.repository.UserRepository;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmService {

    private final FcmTokenRepository fcmTokenRepository;
    private final UserRepository userRepository;

    // FCM 토큰 저장/갱신
    @Transactional
    public void saveToken(UUID userId, String token) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        fcmTokenRepository.findByUser_Id(userId)
                .ifPresentOrElse(
                        fcmToken -> fcmToken.updateToken(token),
                        () -> fcmTokenRepository.save(FcmToken.of(user, token))
                );
    }

    // 알림 전송
    public void sendNotification(UUID receiverId, String title, String body) {
        fcmTokenRepository.findByUser_Id(receiverId).ifPresent(fcmToken -> {
            try {
                Message message = Message.builder()
                        .setNotification(Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build())
                        .setToken(fcmToken.getToken())
                        .build();

                FirebaseMessaging.getInstance().send(message);
                log.info("FCM 알림 전송 성공: {}", receiverId);
            } catch (Exception e) {
                log.error("FCM 알림 전송 실패: {}", e.getMessage());
            }
        });
    }
}