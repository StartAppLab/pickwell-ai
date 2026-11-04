// Handwritten, explicitly synthetic schema/rule fixtures; not evidence of live OCR.
export function labelFixture({basis='per_100g',fat=3,sugars=5,salt=0.3,portion='30 g'}={}) {
 const entries=[['Energy',180,'kcal'],['Total Fat',fat,'g'],['Saturated Fat',1,'g'],
  ['Carbohydrate',30,'g'],['Total Sugars',sugars,'g'],['Protein',8,'g'],['Salt',salt,'g']];
 const nutrients=entries.map(([name,value,unit])=>({name,value,unit,source:`${name} ${value} ${unit}`}));
 const ingredient='Oats, wheat flour, salt. Contains: wheat.';
 return {status:'extracted',retake:[],retake_reasons:[],ingredients:{raw:ingredient,items:['Oats','wheat flour','salt'],declared_allergens:'Contains: wheat.'},
  nutrition:{raw:`${basis==='per_serving'?'Per serving':'Per 100 g'}; serving size ${portion}. `+nutrients.map(v=>v.source).join('; '),
   basis,serving_size:portion,nutrients},
  identity:{nutrition_name:null,ingredients_name:null,consistency:'unknown',food_form:'solid'},
  explanations:[{photo:'ingredients',source:'Oats',text:'The ingredient label states: Oats'},
   {photo:'nutrition',source:nutrients[0].source,text:`The nutrition label states: ${nutrients[0].source}`}]};
}

export function frontLabelFixture(options={}){
 const c=labelFixture(options);
 const observed=(product_name=null)=>({product_name,brand:null,variant:null,net_quantity:null});
 c.identity={front:observed('Synthetic oats'),nutrition:observed(),ingredients:observed(),
  consistency:'unknown',food_form:'solid',conflicts:[]};
 c.interpretation={ingredients:[],nutrition:[],summary_ingredients:[],summary_nutrients:[]};
 return c;
}
