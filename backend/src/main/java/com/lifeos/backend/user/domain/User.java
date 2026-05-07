package com.lifeos.backend.user.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "users")
@Getter
@Setter
public class User extends BaseEntity {

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String timezone;

    @Column(nullable = false)
    private Boolean active = true;

    private String locale = "en";

    @Column(length = 500)
    private String pictureUrl;

    @Column(unique = true, length = 120)
    private String googleSubject;

    @Column(nullable = false)
    private Boolean emailVerified = false;

    public String getLocale() {
        return locale;
    }

    public void setLocale(String locale) {
        this.locale = locale;
    }
}