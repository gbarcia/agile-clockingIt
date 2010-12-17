config_file = File.read RAILS_ROOT + "/config/config.yml"
CONFIG = YAML.load(config_file)
