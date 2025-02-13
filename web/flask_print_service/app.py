from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/print', methods=['POST'])
def print_receipt():
    try:
        # Find your USB device (adjust the vendor and product ID)
        dev = usb.core.find([])

        if dev is None:
            return jsonify({"error": "Dispositivo não encontrado"}), 404

        # Set the active configuration
        dev.set_configuration()

        # Get an endpoint instance
        cfg = dev.get_active_configuration()
        intf = cfg[(0, 0)]

        ep = usb.util.find_descriptor(
            intf,
            custom_match=lambda e: usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_OUT
        )

        if ep is None:
            return jsonify({"error": "Endpoint não encontrado"}), 404

        # Data to be sent to the printer
        data = (
            b'\x1B@'  # Initialize printer (ESC @)
            b'Imprimindo Recibo...\n\n'
            b'Obrigado por sua compra!\n\n'
            b'\x1Bd3'  # Feed 3 lines (ESC d n)
            b'\x1Bm'   # Cut paper (ESC m)
        )

        # Write the data
        ep.write(data)

        return jsonify({"message": "Impressão concluída com sucesso!"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
