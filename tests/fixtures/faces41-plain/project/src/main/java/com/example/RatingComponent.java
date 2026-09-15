package com.example;

import java.io.IOException;

import jakarta.faces.component.FacesComponent;
import jakarta.faces.component.UIComponentBase;
import jakarta.faces.context.FacesContext;
import jakarta.faces.context.ResponseWriter;

@FacesComponent(createTag = true, tagName = "rating", value = "com.example.Rating")
public class RatingComponent extends UIComponentBase {

    @Override
    public String getFamily() {
        return "com.example.Rating";
    }

    @Override
    public void encodeBegin(FacesContext context) throws IOException {
        ResponseWriter writer = context.getResponseWriter();
        writer.startElement("span", this);
        writer.writeAttribute("class", "rating", null);
        writer.writeText(getAttributes().get("value"), this, "value");
        writer.endElement("span");
    }

}
