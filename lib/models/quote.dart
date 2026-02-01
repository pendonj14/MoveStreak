class Quote {
  final String content;
  final String author;

  Quote({
    required this.content,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['content'] as String,
      author: json['author'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'author': author,
  };
}
