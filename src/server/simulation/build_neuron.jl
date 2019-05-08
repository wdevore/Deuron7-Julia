function build_neuron(model::Model.ModelData)
    # A Soma has an Axon for output.
    axon = DirectAxon()

    # Create 80% Excite and 20% Inhibit

    # A neuron has a Soma
    soma = Soma(axon)

    # A neuron is a cell.
    cell = Cell(soma)

    cell
end