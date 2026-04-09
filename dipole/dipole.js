function calculate() {
    const freq = parseFloat(document.getElementById("freqInput").value);
    const result = document.getElementById("result");

    if (!freq || freq <= 0) {
        result.textContent = "Please enter a valid frequency.";
        return;
    }

    // calculate in cm
    // 143 / f gives meters
    const totalLength = (143 / freq) * 100;
    const armLength = totalLength / 2;

    // scale diagram height slightly with size
    const segments = Math.max(3, Math.min(10, Math.round(armLength / 10)));

    let diagram = "";

    // top (blue)
    for (let i = 0; i < segments; i++) {
        diagram += `<span class="top">    │</span>\n`;
    }

    // feed point
    diagram += `<span class="feed">────●────</span> <span class="label">feed point</span>\n`;

    // bottom (red)
    for (let i = 0; i < segments; i++) {
        diagram += `<span class="bottom">    │</span>\n`;
    }

    result.innerHTML = `
<span class="label">Total length:</span> <b>${totalLength.toFixed(1)} cm</b>
<span class="label">Each arm:</span> <b>${armLength.toFixed(1)} cm</b>

${diagram}
<span class="top">Top:</span>    ${armLength.toFixed(1)} cm
<span class="bottom">Bottom:</span> ${armLength.toFixed(1)} cm
`;
}