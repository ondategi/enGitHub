import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

main() {
  
  var decoded = JSON.decode('["foo", { "bar": 499 }]');
  
  Map<String, int> map = decoded[1];
  
  print(decoded);

  print(map["bar"]);
  
  
  List kk3 = JSON.decode('[{"oid":"1398438240369","code":null,"title":"a","completed":"false","updated":"2014-04-23 17:53:23.030"}]');
 // List kk3 = JSON.decode('[{"oid":"1398438240369"},{"code":null},{"title":"a"},{"completed":"false"},{"updated":"2014-04-23 17:53:23.030"}]');
  
  Map kk3tua = JSON.decode('[{"oid":"1398438240369","code":null,"title":"a","completed":"false","updated":"2014-04-23 17:53:23.030"}]');

  Map porfa = new Map();
  kk3.forEach((v){
  //  var deco1 =JSON.decode(v.toString());
    Map<String, dynamic> map44 = v;
    porfa.addAll(map44);
    print(v);
    }); // prints A c a b
  
  print(porfa["oid"]);
  
  String maspor = JSON.encode(porfa);
  print(maspor);


  void displayZip(Map zip) {
    print('partido: ${zip["partido"]}');
  }
  
  Db db = new Db('mongodb://127.0.0.1/mydb');
  
  // concejales a repartir
  int p = 21;
  
  // cargar los datos de los resultados
  var psoe = new ResultadosPartido('PSOE', 3651);
  var upn = new ResultadosPartido('UPN', 2700); // 5400
  var bildu = new ResultadosPartido('Bildu', 382);
  var ie = new ResultadosPartido('IE', 5400); // 2868
  var pp = new ResultadosPartido('PP', 2595);
  var nabai = new ResultadosPartido('NaBai', 536);
  var dne = new ResultadosPartido('DNE', 153);
  
  // crear la lista de resultados de partidos que pasan el 5%
  // para que sean resultados coherentes con la realidad
  List resultados = [psoe, upn, ie, pp];
  
  //imprimir resultados antes del reparto
  resultados.forEach(print);
  
  int i = 0; 
  do {
    i++;
    // ordenar descendente por el resto (votos divididos por escaños obtenidos + 1)
    resultados.sort((x, y) => y.Resto().compareTo(x.Resto()));
    
    // los dos primeros elementos de la lista serán los dos con el resto mas elevado.
    // hay que tratar el caso particular de que tengan el mismo resto.
    // En este caso se asignará el concejal al que tenga mas votos
    
    // la situación habitual es que los restos no coincidan, y que 
    // el ganador sea el primero [0] de la lista (pues está ordenada descendentemente por 'resto'
    int ganador = 0;
    
    // pero, si tienen el mismo resto
    if (resultados[0].Resto().compareTo(resultados[1].Resto()) == 0)
      {
      // el desempate se obtine asignando el escaño al que tenga mas votos 'reales'
      
      // pot tanto, si el segundo [1] tiene mas votos que el primero [0],
      // el segundo [1] gana el escaño
      if (resultados[1].votos.compareTo(resultados[0].votos) > 0) 
          ganador = 1;    
      }
    
    // sumar el concejal al 'ganador'
    resultados[ganador].AsignarConcejal();
 
    resultados.forEach(print);
    } while (i < p);
  
 
  
simpleUpdate() {
  
  DbCollection coll = db.collection('test011');
  // coll.remove();  
  List toInsert = [
                   {"name":"a", "value": 10, "kk": 55},
                   {"name":"b", "value": 20},
                   {"name":"a", "value": 70, "kk": 455},
                   {"name":"c", "value": 30},
                   {"name":"d", "value": 40}
                  ];
 
  // comprobar como va a quedar
  print(resultados[3].toJson());
  
  String encoded = JSON.encode([1, 2, { "a": null }]);
  List decoded = JSON.decode('["foo", { "bar": 499 }]');
  
  print(encoded);
  print(decoded);
  
  
  // toInsert.clear();
  
  // añadir los elementos a la nueva lista toInsert en formato JSON
   resultados.forEach((element) => toInsert.add(element.toJson()));
     
  coll.insertAll(toInsert);
  
  coll.findOne({"name":"c"}).then((v1){
      print("Record c: $v1");
      v1["value"] = 321;    
      coll.save(v1);
      return coll.findOne({"name":"c"});
      }).then((v2){
      print("Record c after update: $v2");
  //  db.drop();
      
       
      //   db.close();
    });

  coll.findOne({"partido":"PSOE"}).then((v1){
      print("Record c: $v1");
      v1["value"] = 321;    
      coll.save(v1);
      return coll.findOne({"partido":"PSOE"});
      }).then((v2){
      print("Record c after update: $v2");
  //  db.drop();
      
        
      
         
         db.close();
    });
  

  }

  db.open().then((c)=>simpleUpdate());
  
  print("Updated MongoDB!");
  

}

// define la clase ResultadosPartido político
class ResultadosPartido {
  String partido; // nombre del partido
  int votos; // votos obtenidos
  int concejales; // concejales conseguidos
  int resto; // (votos divididos por escaños obtenidos + 1)

  ResultadosPartido(String partido, int votos) {
    this.partido = partido;
    this.votos = votos;
    this.concejales = 0;
    this.resto = votos;   
  }
  
  // Setters
  ResultadosPartido.fromJson(String json) {
      Map data = JSON.decode(json);
      partido = data['partido'];
      votos = data['votos'];
    }
  
  AsignarConcejal()
  {   
    // sumar concejal conseguido
    concejales++;
    
    // ahora hay que actualizarle su resto al número de votos
    // dividido por el número de 'concejales' obtenidos hasta el momento + 1
    resto = votos ~/ (concejales + 1);
  }
  
  // Getters
  int Resto() => resto;
  
  // String toJson2() => JSON.encode(this);
  
  // OBLIGATORIO implementarlo para que sepa convertir el objeto 
  // del tipo ResultadosPartido a una cadena json
  Map toJson() => {'partido': partido, 'votos': votos, 'concejales': concejales, 'resto': resto};

  
   
  String toString() {
    String s = "${partido} ha obtenido ${votos} y ${concejales} concejales. Resto actual ${resto}.";
     return s;
    }
  }