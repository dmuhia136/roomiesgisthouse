package com.gistgist.gisthouse;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
//import io.flutter.app.FlutterActivity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.List;

import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private Intent forService;

    private FirebaseAuth mAuth;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        mAuth = FirebaseAuth.getInstance();

        forService = new Intent(MainActivity.this,MyService.class);

        startService();
    }
    private void startService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(forService);
        } else {
            startService(forService);
        }
    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        FirebaseUser currentUser = mAuth.getCurrentUser();
        if (currentUser != null) {
            FirebaseFirestore db = FirebaseFirestore.getInstance();

            db.collection("users").document(currentUser.getUid()).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                @Override
                public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                    if (task.isSuccessful()) {

                        if (task.getResult().getData().get("activeroom") != "") {
                            Log.d("Fred", "Room data " + task.getResult().getData().get("activeroom"));

                            String roomid = task.getResult().getData().get("activeroom").toString();
                            roomLogic(roomid);
                        }
//                        Log.d("Fred", task.getResult().getData().toString());
                    } else {
                        Log.w("Fred", "Error getting documents.", task.getException());
                    }
                }
            });

//            stopService(forService);
            android.util.Log.e("Fred", "destroyed " + currentUser.getUid().toString());
        }
    }

    void roomLogic(String roomid) {
        FirebaseFirestore db = FirebaseFirestore.getInstance();
        FirebaseUser currentUser = mAuth.getCurrentUser();
        Log.w("Fred", "roomLogic" + roomid);
        db.collection("rooms").document(roomid).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(Task<DocumentSnapshot> task) {
                try {
                    if (task.isSuccessful()) {

                        List<String> moderators = (List<String>) task.getResult().getData().get("allmoderators");
                        moderators.remove(currentUser.getUid());
                        if (moderators.size() == 0) {
                            if (task.getResult().getData().get("ownerid").equals(currentUser.getUid())) {
                                android.util.Log.e("Fred", "deleting " + roomid);
                                db.collection("rooms").document(roomid).delete();
                            }
                        }
                        if (moderators.size() > 0) {
                            db.collection("rooms").document(roomid).collection("users").document(currentUser.getUid()).delete();
                        }


                    }
                } catch (Exception e) {
                    android.util.Log.e("Fred", "error " + e.toString());

                }
            }
        });

    }
}

