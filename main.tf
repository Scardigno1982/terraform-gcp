provider "google" {
  credentials = file("tp-opcional-gcp-e806d7933cbb.json")
  project     = "tp-opcional-gcp"
  region      = "us-central1"
}

// Crea una instancia de VM para ejecutar la API
resource "google_compute_instance" "api_instance" {
  name         = "api-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Esto otorgará una IP pública a la VM
    }
  }

  metadata_startup_script = <<-EOT
      sudo apt-get update
      sudo apt-get install -y python3 python3-pip
      echo "from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello_world():
    return 'Hello, API!'
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)" > hello.py
      pip3 install Flask
      nohup python3 hello.py &
    EOT
}

// Otorga acceso a Facundo Miglio
resource "google_project_iam_member" "facundo_access" {
  project = "tp-opcional-gcp"
  role    = "roles/viewer"
  member  = "user:facundo.miglio@educacionit.com"
}

// Regla de firewall para permitir SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Regla de firewall para permitir tráfico a la aplicación Flask en el puerto 8080
resource "google_compute_firewall" "allow_http_8080" {
  name    = "allow-http-8080"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

