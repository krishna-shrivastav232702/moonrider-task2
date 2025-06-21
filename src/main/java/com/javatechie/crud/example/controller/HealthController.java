package com.javatechie.crud.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController{
    @GetMapping("/health")
    public Map<String,Object>health(){
        Map<String,Object> response = new HashMap<>();
        response.put("status","UP");
        response.put("version","1.0.0");
        response.put("timestamp",System.currentTimeMillis());
        return response;
    }
}
