package com.unicloud;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class UniCloudApplication extends Application {

  @Override
  public void start(Stage primaryStage) {
    primaryStage.setTitle("UniCloud - Multi-Cloud File Manager");
    primaryStage.setWidth(800);
    primaryStage.setHeight(600);

    VBox layout = new VBox(20);
    layout.setAlignment(Pos.CENTER);
    layout.setPadding(new Insets(50));
    layout.setStyle("-fx-background-color: #f5f5f5;");

    Label welcomeLabel = new Label("Welcome to UniCloud");
    welcomeLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");

    Label descriptionLabel = new Label("Multi-Cloud File Management Application");
    descriptionLabel.setStyle("-fx-font-size: 14px;");

    Button loginButton = new Button("Login");
    loginButton.setStyle("-fx-min-width: 120px; -fx-min-height: 35px;");
    loginButton.setOnAction(e -> System.out.println("Login clicked"));

    Button registerButton = new Button("Register");
    registerButton.setStyle("-fx-min-width: 120px; -fx-min-height: 35px;");
    registerButton.setOnAction(e -> System.out.println("Register clicked"));

    Button exitButton = new Button("Exit");
    exitButton.setStyle("-fx-min-width: 120px; -fx-min-height: 35px;");
    exitButton.setOnAction(e -> primaryStage.close());

    layout
        .getChildren()
        .addAll(welcomeLabel, descriptionLabel, loginButton, registerButton, exitButton);

    Scene scene = new Scene(layout);
    primaryStage.setScene(scene);
    primaryStage.show();
  }

  public static void main(String[] args) {
    launch(args);
  }
}
