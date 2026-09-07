package com.example;

import java.io.Serializable;
import java.util.Objects;

public class OrderStatus implements Serializable {

    private static final long serialVersionUID = 1L;

    private String code;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof OrderStatus status && Objects.equals(code, status.code);
    }

    @Override
    public int hashCode() {
        return Objects.hash(code);
    }

}
