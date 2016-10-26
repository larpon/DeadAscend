package com.bitkompot.android.hammerbees;

import org.qtproject.qt5.android.bindings.QtApplication;
import org.qtproject.qt5.android.bindings.QtActivity;

import android.util.Log;
import android.os.Bundle;

import android.view.WindowManager;

import org.dreamdev.QtAdMob.QtAdMobActivity;

public class Main extends QtAdMobActivity {

    /** Called when the activity is first created. */

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

    }

}
