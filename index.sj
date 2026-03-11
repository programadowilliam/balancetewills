// Estado da aplicação
let receitas = [];
let despesas = [];

// Elementos do DOM
const tabelaBody = document.getElementById('tabela-body');
const descricaoInput = document.getElementById('descricao');
const valorInput = document.getElementById('valor');
const tituloInput = document.getElementById('titulo');

// Formata valor para exibição
function formatarValor(valor) {
    return valor.toFixed(2).replace('.', ',');
}

// Atualiza a tabela e os totais
function atualizarTabela() {
    // Limpa a tabela
    tabelaBody.innerHTML = '';

    // Adiciona receitas
    receitas.forEach((item, index) => {
        const row = document.createElement('tr');
        row.className = 'receita-row';
        row.innerHTML = `
            <td><button class="remove-btn" onclick="removerReceita(${index})">✕</button></td>
            <td>${item.descricao}</td>
            <td>R$ ${formatarValor(item.valor)}</td>
            <td>-</td>
        `;
        tabelaBody.appendChild(row);
    });

    // Adiciona despesas
    despesas.forEach((item, index) => {
        const row = document.createElement('tr');
        row.className = 'despesa-row';
        row.innerHTML = `
            <td><button class="remove-btn" onclick="removerDespesa(${index})">✕</button></td>
            <td>${item.descricao}</td>
            <td>-</td>
            <td>R$ ${formatarValor(item.valor)}</td>
        `;
        tabelaBody.appendChild(row);
    });

    // Calcula totais
    const totalReceitas = receitas.reduce((acc, item) => acc + item.valor, 0);
    const totalDespesas = despesas.reduce((acc, item) => acc + item.valor, 0);
    const saldo = totalReceitas - totalDespesas;

    // Atualiza totais
    document.getElementById('total-receitas').textContent = `R$ ${formatarValor(totalReceitas)}`;
    document.getElementById('total-despesas').textContent = `R$ ${formatarValor(totalDespesas)}`;
    
    const saldoElement = document.getElementById('saldo');
    saldoElement.textContent = `R$ ${formatarValor(Math.abs(saldo))}`;
    saldoElement.className = `total-value ${saldo >= 0 ? 'saldo-positivo' : 'saldo-negativo'}`;
    if (saldo < 0) {
        saldoElement.textContent = `-R$ ${formatarValor(Math.abs(saldo))}`;
    }
}

// Adicionar receita
function adicionarReceita() {
    const descricao = descricaoInput.value.trim();
    const valor = parseFloat(valorInput.value);

    if (!descricao || isNaN(valor) || valor <= 0) {
        alert('Por favor, preencha a descrição e um valor válido!');
        return;
    }

    receitas.push({ descricao, valor });
    limparCampos();
    atualizarTabela();
}

// Adicionar despesa
function adicionarDespesa() {
    const descricao = descricaoInput.value.trim();
    const valor = parseFloat(valorInput.value);

    if (!descricao || isNaN(valor) || valor <= 0) {
        alert('Por favor, preencha a descrição e um valor válido!');
        return;
    }

    despesas.push({ descricao, valor });
    limparCampos();
    atualizarTabela();
}

// Remover receita
function removerReceita(index) {
    receitas.splice(index, 1);
    atualizarTabela();
}

// Remover despesa
function removerDespesa(index) {
    despesas.splice(index, 1);
    atualizarTabela();
}

// Limpar campos do formulário
function limparCampos() {
    descricaoInput.value = '';
    valorInput.value = '';
}

// Gerar PDF
function gerarPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    
    // Título
    doc.setFontSize(16);
    doc.text(tituloInput.value, 14, 20);
    
    // Data de geração
    doc.setFontSize(10);
    doc.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')}`, 14, 28);
    
    // Receitas
    doc.setFontSize(14);
    doc.text('RECEITAS:', 14, 40);
    
    let y = 48;
    doc.setFontSize(11);
    receitas.forEach(item => {
        doc.text(`${item.descricao} - R$ ${formatarValor(item.valor)}`, 14, y);
        y += 8;
    });
    
    // Despesas
    y += 5;
    doc.setFontSize(14);
    doc.text('DESPESAS:', 14, y);
    
    y += 8;
    doc.setFontSize(11);
    despesas.forEach(item => {
        doc.text(`${item.descricao} - R$ ${formatarValor(item.valor)}`, 14, y);
        y += 8;
    });
    
    // Totais
    y += 10;
    const totalReceitas = receitas.reduce((acc, item) => acc + item.valor, 0);
    const totalDespesas = despesas.reduce((acc, item) => acc + item.valor, 0);
    const saldo = totalReceitas - totalDespesas;
    
    doc.setFontSize(12);
    doc.setFont(undefined, 'bold');
    doc.text(`Total Receitas: R$ ${formatarValor(totalReceitas)}`, 14, y);
    y += 8;
    doc.text(`Total Despesas: R$ ${formatarValor(totalDespesas)}`, 14, y);
    y += 8;
    doc.text(`Saldo: R$ ${formatarValor(Math.abs(saldo))} ${saldo < 0 ? '(Negativo)' : ''}`, 14, y);
    
    // Salvar PDF
    doc.save(`${tituloInput.value.replace(/ /g, '_')}.pdf`);
}

// Inicializa a tabela vazia
atualizarTabela();
