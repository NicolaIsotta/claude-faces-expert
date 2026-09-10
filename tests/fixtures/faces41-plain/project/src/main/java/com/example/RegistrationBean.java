package com.example;

import java.io.Serializable;
import java.util.List;

import jakarta.annotation.PostConstruct;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;

@Named
@ViewScoped
public class RegistrationBean implements Serializable {

    private static final long serialVersionUID = 1L;

    @Inject
    private TopicService topicService;

    private String email;
    private String name;
    private String username;
    private String password;
    private List<String> topics;
    private List<String> availableTopics;
    private boolean newsletterEnabled;
    private boolean trialAccount;

    @PostConstruct
    public void init() {
        topics = List.of("releases");
        newsletterEnabled = true;
        trialAccount = true;
    }

    public List<String> getAvailableTopics() {
        if (availableTopics == null) {
            availableTopics = topicService.listAll();
        }

        return availableTopics;
    }

    public String register() {
        return "confirmation?faces-redirect=true";
    }

    public String subscribe() {
        return "subscribed?faces-redirect=true";
    }

    public String login() {
        return "dashboard?faces-redirect=true";
    }

    public String remindPassword() {
        return "reminder?faces-redirect=true";
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public List<String> getTopics() {
        return topics;
    }

    public void setTopics(List<String> topics) {
        this.topics = topics;
    }

    public boolean isNewsletterEnabled() {
        return newsletterEnabled;
    }

    public boolean isTrialAccount() {
        return trialAccount;
    }

}
