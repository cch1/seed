namespace :db do  
  #  Load seed data from YAML files into ActiveRecord models.
  #  The YAML seeds can reference any attribute of the model, including
  #  virtual attributes.  YAML files are loaded in lexical order and
  #  leading digits followed by an underscore are stripped to determine the
  #  ActiveRecord model into which the seed data is to be loaded.
  #  
  #  Seed attributes are bulk-assigned to model instances.  However, if this
  #  presents problems (as is likely to be the case with protected attributes)
  #  you can define a #seed instance method that takes a hash of attributes.  The
  #  seed method is responsible for preparing the model for saving.
  #
  #  Note that if the id of the seed is provided in the YAML data, existing
  #  seeds are updated instead of created.
  desc "Loads seed data for the current environment."
  task :seed => :environment do
    Dir[File.join(Rails.root, 'db', 'seeds', '*.yml')].sort.each do |seed_file|
      model = File.basename(seed_file, '.yml')[/\A(?:\d+_)?(\w+)\Z/, 1].classify.constantize
      YAML.load(ERB.new(File.read(seed_file)).result).each do |name, attrs|
        attrs.stringify_keys!
        id = attrs.delete(model.primary_key)
        # TODO: change find_or_initialize... to use the proper primary key name.
        returning model.find_or_initialize_by_id(id) do |mi|
          mi.respond_to?(:seed) ? mi.seed(attrs) : mi.attributes = attrs
          mi.save!
        end
      end
    end
  end
end