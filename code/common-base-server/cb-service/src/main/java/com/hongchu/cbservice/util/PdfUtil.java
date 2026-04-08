package com.hongchu.cbservice.util;

import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * PDF工具类
 * 用于将PDF转换为图片
 */
@Slf4j
public class PdfUtil {

    private static final int MAX_PAGES = 5;
    private static final float DPI = 150f;
    private static final int MAX_WIDTH = 1024;
    private static final String IMAGE_FORMAT = "png";

    private PdfUtil() {
    }

    /**
     * 将PDF文件的每一页转换为图片
     *
     * @param pdfBytes PDF文件字节数组
     * @return 图片字节数组列表，每个元素代表一页
     * @throws IOException 如果PDF解析失败
     */
    public static List<byte[]> convertPdfToImages(byte[] pdfBytes) throws IOException {
        List<byte[]> images = new ArrayList<>();
        
        try (PDDocument document = PDDocument.load(pdfBytes)) {
            int totalPages = document.getNumberOfPages();
            int pagesToProcess = Math.min(totalPages, MAX_PAGES);
            
            if (totalPages > MAX_PAGES) {
                log.warn("PDF共有{}页，仅处理前{}页", totalPages, MAX_PAGES);
            }
            
            PDFRenderer renderer = new PDFRenderer(document);
            
            for (int i = 0; i < pagesToProcess; i++) {
                BufferedImage image = renderer.renderImageWithDPI(i, DPI, ImageType.RGB);
                image = resizeIfNeeded(image);
                
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                ImageIO.write(image, IMAGE_FORMAT, baos);
                images.add(baos.toByteArray());
                
                log.debug("已转换PDF第{}页为图片，大小: {} bytes", i + 1, baos.size());
            }
        }
        
        return images;
    }

    /**
     * 如果图片宽度超过最大宽度，则等比缩放
     */
    private static BufferedImage resizeIfNeeded(BufferedImage original) {
        int width = original.getWidth();
        int height = original.getHeight();
        
        if (width <= MAX_WIDTH) {
            return original;
        }
        
        double scale = (double) MAX_WIDTH / width;
        int newWidth = MAX_WIDTH;
        int newHeight = (int) (height * scale);
        
        BufferedImage resized = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_RGB);
        java.awt.Graphics2D g2d = resized.createGraphics();
        g2d.drawImage(original, 0, 0, newWidth, newHeight, null);
        g2d.dispose();
        
        log.debug("图片已缩放: {}x{} -> {}x{}", width, height, newWidth, newHeight);
        return resized;
    }

    /**
     * 压缩图片（如果超过指定大小）
     *
     * @param imageBytes 原始图片字节数组
     * @param maxSizeKB  最大大小（KB）
     * @return 压缩后的图片字节数组
     */
    public static byte[] compressImageIfNeeded(byte[] imageBytes, int maxSizeKB) throws IOException {
        int maxSizeBytes = maxSizeKB * 1024;
        
        if (imageBytes.length <= maxSizeBytes) {
            return imageBytes;
        }
        
        BufferedImage image = ImageIO.read(new java.io.ByteArrayInputStream(imageBytes));
        if (image == null) {
            return imageBytes;
        }
        
        float quality = 0.8f;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        while (imageBytes.length > maxSizeBytes && quality > 0.1f) {
            baos.reset();
            
            javax.imageio.ImageWriter writer = ImageIO.getImageWritersByFormatName("jpg").next();
            javax.imageio.ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(javax.imageio.ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(quality);
            
            writer.setOutput(ImageIO.createImageOutputStream(baos));
            writer.write(null, new javax.imageio.IIOImage(image, null, null), param);
            writer.dispose();
            
            imageBytes = baos.toByteArray();
            quality -= 0.1f;
        }
        
        log.debug("图片已压缩: {} -> {} bytes", imageBytes.length, baos.size());
        return imageBytes;
    }
}
