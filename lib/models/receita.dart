class Receita {
  final int? id;
  final String nome;
  final String tipo; 
  final String ingredientes;
  final String modoFazer;
  final String img;
  final double custoAproximado;

  const Receita({
    this.id,
    required this.nome,
    required this.tipo,
    required this.ingredientes,
    required this.modoFazer,
    this.img = '',
    this.custoAproximado = 0,
  });

  static const tipos = ['DOCE', 'SALGADA', 'BEBIDA'];

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json['id'] as int?,
      nome: (json['nome'] ?? '') as String,
      tipo: (json['tipo'] ?? 'SALGADA') as String,
      ingredientes: (json['ingredientes'] ?? '') as String,
      modoFazer: (json['modoFazer'] ?? '') as String,
      img: (json['img'] ?? '') as String,
      custoAproximado: double.tryParse('${json['custoAproximado']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'tipo': tipo,
        'ingredientes': ingredientes,
        'modoFazer': modoFazer,
        'img': img,
        'custoAproximado': custoAproximado,
      };

  String get tipoLabel {
    switch (tipo) {
      case 'DOCE':
        return 'Doce';
      case 'BEBIDA':
        return 'Bebida';
      default:
        return 'Salgada';
    }
  }
}
