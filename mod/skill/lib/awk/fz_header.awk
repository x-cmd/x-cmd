BEGIN {
    # Generate header that matches the optimized data format
    # Column widths should match those in fz_data_optimized.awk

    # Format: Emoji(3) + Name(25) + Author(15) + Description(60) + License(12) + ID(8)
    # Total: 3 + 25 + 15 + 60 + 12 + 8 = 123 characters

    # Create header with proper spacing to match data columns
    emoji_col = "⚡"
    name_col = "Name"
    author_col = "Author"
    desc_col = "Description"
    license_col = "License"
    id_col = "ID"

    # Build header with proper spacing to match data column widths
    header = sprintf("%-3s %-32s %-12s %-60s %-12s %-8s",
                     emoji_col, name_col, author_col, desc_col, license_col, id_col)

    print header
}