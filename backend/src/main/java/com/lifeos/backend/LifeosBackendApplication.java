package com.lifeos.backend;

import com.lifeos.backend.common.config.AiServiceProperties;

import com.lifeos.backend.common.config.GooglePlacesProperties;

import com.lifeos.backend.common.config.PayWayProperties;

import org.springframework.boot.SpringApplication;

import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication

@EnableConfigurationProperties({

		GooglePlacesProperties.class,

		AiServiceProperties.class,

		PayWayProperties.class

})

public class LifeosBackendApplication {

	public static void main(String[] args) {

		SpringApplication.run(LifeosBackendApplication.class, args);

	}

}