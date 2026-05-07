package com.lifeos.backend.support;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
public abstract class BaseE2ETest {

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;

    @Autowired
    protected TestDataHelper testDataHelper;

    @Autowired
    protected AuthTestHelper authTestHelper;

    protected final MediaType json = MediaType.APPLICATION_JSON;

    protected String toJson(Object value) throws Exception {
        return objectMapper.writeValueAsString(value);
    }
}