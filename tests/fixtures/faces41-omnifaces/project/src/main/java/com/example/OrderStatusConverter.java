package com.example;

import jakarta.enterprise.context.Dependent;
import jakarta.faces.component.UIComponent;
import jakarta.faces.context.FacesContext;
import jakarta.faces.convert.Converter;
import jakarta.faces.convert.FacesConverter;
import jakarta.inject.Inject;

@Dependent
@FacesConverter(value = "orderStatusConverter", managed = true)
public class OrderStatusConverter implements Converter<OrderStatus> {

    @Inject
    private StatusService statusService;

    @Override
    public String getAsString(FacesContext context, UIComponent component, OrderStatus status) {
        if (status == null) {
            return "";
        }

        return status.getCode();
    }

    @Override
    public OrderStatus getAsObject(FacesContext context, UIComponent component, String code) {
        if (code == null || code.isEmpty()) {
            return null;
        }

        return statusService.findByCode(code);
    }

}
