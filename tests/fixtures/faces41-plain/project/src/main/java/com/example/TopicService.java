package com.example;

import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class TopicService {

    public List<String> listAll() {
        return List.of("releases", "security", "events");
    }

}
