def remove_duplicates(file_path):
    """Remove duplicate lines from a file while preserving order."""
    seen = set()
    unique_lines = []

    with open(file_path, "r") as file:
        for line in file:
            if line not in seen:
                seen.add(line)
                unique_lines.append(line)

    with open(file_path, "w") as file:
        file.writelines(unique_lines)

    print(f"✅ Removed duplicates from {file_path}")

# Run the function
remove_duplicates("activity_ids.txt")
