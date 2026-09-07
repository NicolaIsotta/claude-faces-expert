package com.example;

import java.util.UUID;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.ConverterException;
import javax.faces.convert.FacesConverter;

@FacesConverter("uuidConverter")
public class UuidConverter implements Converter<UUID> {

    @Override
    public String getAsString(FacesContext context, UIComponent component, UUID uuid) {
        if (uuid == null) {
            return "";
        }

        return uuid.toString();
    }

    @Override
    public UUID getAsObject(FacesContext context, UIComponent component, String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }

        try {
            return UUID.fromString(value);
        }
        catch (IllegalArgumentException e) {
            throw new ConverterException(new FacesMessage("Invalid reference."), e);
        }
    }

}
