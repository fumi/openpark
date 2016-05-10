# Constants variables

PARK_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/parks/")
EQUIPMENT_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/equipment/")
ORGANIZATION_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/organizations/")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/rdf#")
PARK = RDF::Vocabulary.new("http://openpark.jp/ns/park#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::Vocab::SCHEMA.to_s,
  :geo => RDF::Vocab::GEO.to_s,
  :dcterms => RDF::Vocab::DC.to_s,
  :xsd => RDF::XSD.to_s,
  :park_resource => PARK_RESOURCE.to_s,
  :equipment_resource => EQUIPMENT_RESOURCE.to_s,
  :organization_resource => ORGANIZATION_RESOURCE.to_s,
  :ic => IC.to_s,
  :park => PARK.to_s
}

