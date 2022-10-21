package com.burfordfc.service.TestService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TestServiceApplication {
	private static final Logger logger = LoggerFactory.getLogger(TestServiceApplication.class);

	public static void main(String[] args) {
		logger.info("Version 3");
		SpringApplication.run(TestServiceApplication.class, args);
	}
}
