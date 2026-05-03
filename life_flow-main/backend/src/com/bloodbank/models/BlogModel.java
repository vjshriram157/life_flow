package com.bloodbank.models;

import java.io.Serializable;

public class BlogModel implements Serializable {
    private String id;
    private String title;
    private String category;
    private String date;
    private String author;
    private String preview;
    private String content;
    private String icon;
    private String imageUrl;

    public BlogModel() {}

    public BlogModel(String id, String title, String category, String date, String author, String preview, String content, String imageUrl, String icon) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.date = date;
        this.author = author;
        this.preview = preview;
        this.content = content;
        this.imageUrl = imageUrl;
        this.icon = icon;
    }

    // Getters and Setters
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getPreview() { return preview; }
    public void setPreview(String preview) { this.preview = preview; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}
