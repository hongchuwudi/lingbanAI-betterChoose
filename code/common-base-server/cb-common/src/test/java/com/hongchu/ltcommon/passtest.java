package com.hongchu.ltcommon;

import com.hongchu.cbcommon.util.SimplePasswordEncoder;

public class passtest {
    public static void main(String[] args) {
        String password = "123456";
        String salt = SimplePasswordEncoder.generateSalt();
        String hash = SimplePasswordEncoder.encrypt(password, salt);
        System.out.println("Salt: " + salt);
        System.out.println("Hash: " + hash);
    }
}
