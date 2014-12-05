# Constants variables

PARK_RESOURCE = RDF::Vocabulary.new("http://yokohama.openpark.jp/parks/")
EQUIPMENT_RESOURCE = RDF::Vocabulary.new("http://yokohama.openpark.jp/equipment/")
ORGANIZATION_RESOURCE = RDF::Vocabulary.new("http://yokohama.openpark.jp/organizations/")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/210#")
PARK = RDF::Vocabulary.new("http://yokohama.openpark.jp/ns/park#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::SCHEMA.to_s,
  :geo => RDF::GEO.to_s,
  :dcterms => RDF::DC.to_s,
  :xsd => RDF::XSD.to_s,
  :park_resource => PARK_RESOURCE.to_s,
  :equipment_resource => EQUIPMENT_RESOURCE.to_s,
  :organization_resource => ORGANIZATION_RESOURCE.to_s,
  :ic => IC.to_s,
  :park => PARK.to_s
}

