<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contract {{ $contract->contract_number }}</title>
    <style>
        @page { margin: 60px; size: A4; }
        body { font-family: 'DejaVu Sans', sans-serif; color: #1f2937; line-height: 1.6; font-size: 12px; }
        h1 { text-align: center; font-size: 22px; margin-bottom: 6px; }
        .sub { text-align: center; font-size: 11px; color: #6b7280; margin-bottom: 30px; }
        .section { margin-bottom: 18px; }
        .section-title { font-weight: 700; font-size: 13px; margin-bottom: 6px; text-transform: uppercase; border-bottom: 1px solid #e5e7eb; padding-bottom: 4px; }
        .row { margin-bottom: 4px; }
        .label { font-weight: 600; }
        .terms { text-align: justify; }
        .signature-box { margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 12px; }
        .signature-img { max-height: 80px; margin-top: 6px; }
        .footer { margin-top: 60px; display: flex; justify-content: space-between; }
        .sign-line { border-top: 1px solid #374151; width: 200px; margin-top: 40px; padding-top: 4px; font-size: 11px; }
    </style>
</head>
<body>
    <h1>TENANCY AGREEMENT</h1>
    <p class="sub">Contract No: {{ $contract->contract_number }} &bull; {{ $contract->contract_type === 'manual' ? 'Manual' : 'Digital' }}</p>

    <div class="section">
        <div class="section-title">1. Parties</div>
        <div class="row"><span class="label">Landlord:</span> {{ $contract->organization?->business_name ?? 'Manna Apartment' }}</div>
        <div class="row"><span class="label">Tenant:</span> {{ $contract->tenant?->user?->full_name ?? 'N/A' }}</div>
        <div class="row"><span class="label">Phone:</span> {{ $contract->tenant?->user?->phone ?? 'N/A' }}</div>
        <div class="row"><span class="label">ID Number:</span> {{ $contract->tenant?->id_number ?? 'N/A' }}</div>
    </div>

    <div class="section">
        <div class="section-title">2. Property</div>
        <div class="row"><span class="label">Property:</span> {{ $contract->unit?->property?->name ?? 'N/A' }}</div>
        <div class="row"><span class="label">Address:</span> {{ $contract->unit?->property?->address ?? $contract->unit?->property?->location ?? 'N/A' }}</div>
        <div class="row"><span class="label">Unit:</span> {{ $contract->unit?->name ?? $contract->unit?->unit_number ?? 'N/A' }}</div>
    </div>

    <div class="section">
        <div class="section-title">3. Term</div>
        <div class="row"><span class="label">Start Date:</span> {{ $contract->start_date?->format('d M Y') ?? 'N/A' }}</div>
        <div class="row"><span class="label">End Date:</span> {{ $contract->end_date?->format('d M Y') ?? 'N/A' }}</div>
        <div class="row"><span class="label">Duration:</span> {{ str_replace('_', ' ', $contract->duration_type) }}</div>
    </div>

    <div class="section">
        <div class="section-title">4. Rent</div>
        <div class="row"><span class="label">Monthly Rent:</span> TZS {{ number_format($contract->rent_amount, 2) }}</div>
        <div class="row"><span class="label">Deposit:</span> TZS {{ number_format($contract->deposit_amount ?? 0, 2) }}</div>
    </div>

    <div class="section">
        <div class="section-title">5. Terms and Conditions</div>
        <p class="terms">
            The tenant agrees to pay rent on or before the due date each month. The tenant shall keep the property and unit in good condition and comply with all house rules. The landlord may terminate this agreement for non-payment, breach of terms, or misuse of the property. The deposit shall be refunded at move-out after inspection, minus any damages or unpaid dues.
        </p>
    </div>

    @if($signatureBase64)
    <div class="signature-box">
        <div class="section-title">Signature</div>
        <p class="terms">This contract was signed electronically on {{ $contract->signed_at?->format('d M Y H:i') ?? now()->format('d M Y H:i') }}.</p>
        <img src="{{ $signatureBase64 }}" class="signature-img" alt="Signature">
    </div>
    @else
    <div class="footer">
        <div>
            <div class="sign-line">Landlord Signature</div>
        </div>
        <div>
            <div class="sign-line">Tenant Signature</div>
        </div>
    </div>
    @endif
</body>
</html>
