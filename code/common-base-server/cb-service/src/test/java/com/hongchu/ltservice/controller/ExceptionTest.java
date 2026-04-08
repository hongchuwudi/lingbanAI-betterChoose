package com.hongchu.ltservice.controller;
public class ExceptionTest {
    public int[] arr = {1, 3, 4, 5};
    public static void main(String[] args) {
        ExceptionTest test = new ExceptionTest();
        try {
            // 故意访问越界的数组元素
            System.out.println("数组越界元素: " + test.arr[10]);
        }
        catch (NullPointerException e) {  // 错误顺序1：不匹配的异常类型
            System.out.println("捕获到NullPointerException");
        }
        catch (ArithmeticException e) {   // 错误顺序2：不匹配的异常类型
            System.out.println("捕获到ArithmeticException");
        }
        catch (ArrayIndexOutOfBoundsException e) {  // 正确匹配的异常
            System.out.println("捕获到ArrayIndexOutOfBoundsException: " + e.getMessage());
        }
        catch (RuntimeException e) {  // 也能捕获，但会被前面的catch块先处理
            System.out.println("捕获到RuntimeException");
        }
        finally {
            System.out.println("finally块总是会执行");
        }
        System.out.println("程序继续执行...");
    }
}
