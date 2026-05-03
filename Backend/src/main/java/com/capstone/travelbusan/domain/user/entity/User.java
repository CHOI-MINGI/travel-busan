package com.capstone.travelbusan.domain.user.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "user_id", updatable = false, nullable = false)
    private UUID id;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 100)
    private String nickname;

    @Column(name = "social_provider", length = 50)
    private String socialProvider;

    @Column(name = "profile_image_url", columnDefinition = "TEXT")
    private String profileImageUrl;

    @Column(name = "is_guide", nullable = false)
    private boolean isGuide = false;

    @Column(name = "failed_login_attempts", nullable = false)
    private int failedLoginAttempts = 0;

    // --- 비즈니스 메서드 ---

    // 0. 회원가입용 생성자
    public static User create(String email, String encodedPassword, String nickname) {
        User user = new User();
        user.email = email;
        user.password = encodedPassword;
        user.nickname = nickname;
        user.isGuide = false;
        user.failedLoginAttempts = 0;
        return user;
    }
    // 1. 로그인 실패 횟수 증가
    public void incrementFailedLoginAttempts() {
        this.failedLoginAttempts++;
    }

    // 2. 로그인 실패 횟수 초기화
    public void resetFailedLoginAttempts() {
        this.failedLoginAttempts = 0;
    }

    // ★ 3. 가이드 권한 부여 플래그 수정 로직 (추가된 부분)
    public void promoteToGuide() {
        if (this.isGuide) {
            throw new IllegalStateException("이미 가이드 권한을 가진 사용자입니다.");
        }
        this.isGuide = true;
    }
}