package com.example;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class StockService {

    public boolean isAvailable(int quantity) {
        return quantity > 0;
    }

}
