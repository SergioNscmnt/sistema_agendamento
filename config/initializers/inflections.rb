# config/initializers/inflections.rb

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.clear

  # Regras gerais de pluralização e singularização em pt-BR
  inflect.plural(/ão$/i, 'ões')
  inflect.singular(/ões$/i, 'ão')

  inflect.plural(/al$/i, 'ais')
  inflect.singular(/ais$/i, 'al')

  inflect.plural(/el$/i, 'eis')
  inflect.singular(/eis$/i, 'el')

  inflect.plural(/il$/i, 'is')
  inflect.singular(/is$/i, 'il')

  inflect.plural(/m$/i, 'ns')
  inflect.singular(/ns$/i, 'm')

  inflect.plural(/([^aeiou])l$/i, '\1is')  # papel → papeis
  inflect.singular(/([^aeiou])is$/i, '\1l')

  inflect.plural(/([^c])r$/i, '\1res')     # trabalhador → trabalhadores
  inflect.singular(/res$/i, 'r')

  inflect.plural(/s$/i, 'ses')
  inflect.singular(/ses$/i, 's')

  inflect.irregular 'país', 'países'
  inflect.irregular 'cão', 'cães'
  inflect.irregular 'mão', 'mãos'
  inflect.irregular 'irmão', 'irmãos'
  inflect.irregular 'pão', 'pães'
  inflect.irregular 'artesão', 'artesãos'
  inflect.irregular 'capitão', 'capitães'

  # Algumas palavras não mudam
  inflect.uncountable %w[status tórax lápis ônibus vírus atlas]

  # Acrônimos (opcional)
  inflect.acronym 'API'
  inflect.acronym 'URL'
  inflect.acronym 'HTML'
end
