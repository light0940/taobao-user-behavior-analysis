# raw_data

该目录用于本地存放数据文件。由于原始数据体积较大，GitHub 仓库不直接上传 CSV。

请从阿里天池 UserBehavior 数据集下载原始文件，并放置为：

```text
raw_data/UserBehavior.csv
```

运行顺序：

```bash
python sample_data.py
python clean_data.py
```

生成文件：

```text
raw_data/UserBehavior_sample_1pct.csv
raw_data/UserBehavior_clean.csv
```
