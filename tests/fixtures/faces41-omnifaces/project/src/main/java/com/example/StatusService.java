package com.example;

import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class StatusService {

    public OrderStatus findByCode(String code) {
        return new OrderStatus();
    }

    public List<OrderStatus> listAll() {
        return List.of();
    }

}
