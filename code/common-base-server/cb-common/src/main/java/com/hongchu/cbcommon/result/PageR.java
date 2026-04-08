// PageVO.java - 通用的分页响应类
package com.hongchu.cbcommon.result;

import lombok.Data;
import java.util.List;

@Data
public class PageR<T> {
    private Long total;                 // 总记录数
    private Long pages ;                // 总页数
    private Long current = 1L;          // 当前页码
    private Long size = 10L;            // 每页记录数
    private List<T> records;            // 当前页数据
}