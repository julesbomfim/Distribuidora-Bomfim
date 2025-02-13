async function connectAndPrint() {
    try {
        const device = await navigator.usb.requestDevice({ filters: [] });
        console.log('Dispositivo encontrado:', device.productName);

        await device.open();
        if (device.configuration === null) {
            await device.selectConfiguration(1);
        }

        console.log('Configurações e interfaces disponíveis:', device.configuration.interfaces);

        // Itera sobre as interfaces disponíveis
        for (const iface of device.configuration.interfaces) {
            try {
                await device.claimInterface(iface.interfaceNumber);
                console.log(`Interface ${iface.interfaceNumber} reivindicada com sucesso.`);

                // Itera sobre os endpoints da interface
                for (const endpoint of iface.alternates[0].endpoints) {
                    if (endpoint.direction === 'out') {
                        console.log(`Tentando endpoint: ${endpoint.endpointNumber}`);

                        // Tentativa de enviar dados para o endpoint
                        const encoder = new TextEncoder();
                        const data = encoder.encode(
                            '\x1B@' + // Initialize printer (ESC @)
                            'Imprimindo Recibo...\n\n' +
                            'Obrigado por sua compra!\n\n' +
                            '\x1Bd3' + // Feed 3 lines (ESC d n)
                            '\x1Bm'    // Cut paper (ESC m)
                        );

                        const result = await device.transferOut(endpoint.endpointNumber, data);
                        console.log('Resultado da transferência:', result);

                        // Se a transferência foi bem-sucedida, feche o dispositivo
                        await device.close();
                        console.log('Impressão concluída com sucesso!');
                        return;
                    }
                }

            } catch (interfaceError) {
                console.error(`Erro ao usar a interface ${iface.interfaceNumber}:`, interfaceError);
            }
        }

        console.error('Nenhuma interface ou endpoint válido encontrado.');
        alert('Erro ao se conectar à impressora. Verifique a conexão e tente novamente.');

        await device.close();
    } catch (error) {
        console.error('Erro durante a impressão:', error);
        alert('Erro ao se conectar à impressora. Verifique a conexão e tente novamente.');
    }
}
