# Custom PDF tools

## [1] PDF color convert script with Graphicsmagick(http://graphicsmagick.org)
This simple shell script can convert scanned PDF documents into monochrome, grayscale, or n-colored. This is done with the Graphicsmagick(http://graphicsmagick.org).

**[FEATURES]**
- Convert PDF into several color options (mono, gray, 1-)
  - (with secondary effect of shrinking PDF size, when reducing color.)
- Change DPI
- Preserve page box
- Batch processing (4 pages)

**[REQUIREMENTS]**
- Graphicsmagick(http://graphicsmagick.org)
- pdfseparate, pdfunite

**[BASIC USAGE]**
1. Install requirements
2. Download the script("pdf_color.sh")
3. Give the script permission to execute /ex/ `chmod +x pdf_color.sh`
4. Run the script:
  - Basic usage: `./pdf_color.sh FILE_NAME COLOR_MODE INPUT_DPI OUTPUT_DPI`
    - FILE_NAME: PDF file location; names with spaces should be "quoted"(?)
    - COLOR_MODE: output color options; can be `mono`, `gray`, `1`, ...; default value is `mono` if omitted
    - INPUT_DPI: DPI of input pdf file; default value is `600` if omitted
    - OUTPUT_DPI: DPI of output pdf file; default value is `400` if omitted
  - Examples:
    - Convert 400dpi PDF(sample.pdf) into 400dpi grayscale: `./pdf_color.sh sample.pdf gray 400 400`
    - Convert 600dpi PDF(sample.pdf) into 400dpi 8-colored: `./pdf_color.sh sample.pdf 8`
    
**[APPENDIX]**
I made this script to shrink my scanned pdfs. My basic workflow is following:
1. I scan the original document(mostly books) with 600dpi in full color. In most time, a single scanned book is about 500Mb~1Gb.
2. While keeping the original file, I usually convert it into monochrome(for text-only books) or 6-colored(for colored books) for iPad. This mostly reduces the file size about 50-80%(10-50Mb).
3. Then I archive the original file on my external drives and delete it from my local drive.
