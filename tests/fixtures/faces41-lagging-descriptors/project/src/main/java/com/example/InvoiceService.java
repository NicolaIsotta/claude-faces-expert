package com.example;

import java.math.BigDecimal;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class InvoiceService {

    public BigDecimal findAmount(Long id) {
        return BigDecimal.ZERO;
    }

    public void save(Long id, BigDecimal amount) {
        // Persists the invoice.
    }

}
